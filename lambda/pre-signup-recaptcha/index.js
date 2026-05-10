const axios = require('axios');

exports.handler = async (event) => {
  const { request } = event;
  const { userAttributes } = request;
  const recaptchaToken = userAttributes['custom:recaptchaToken'];
  
  if (!recaptchaToken) {
    throw new Error('Missing reCAPTCHA token');
  }
  
  try {
    const response = await axios.post(
      'https://www.google.com/recaptcha/api/siteverify',
      null,
      {
        params: {
          secret: process.env.RECAPTCHA_SECRET_KEY,
          response: recaptchaToken,
        },
      }
    );
    
    if (!response.data.success || response.data.score < 0.5) {
      throw new Error('reCAPTCHA verification failed');
    }
    
    // Check rate limiting
    const email = userAttributes.email;
    const redis = require('ioredis');
    const redisClient = new redis(process.env.REDIS_URL);
    
    const attempts = await redisClient.incr(`signup:${email}`);
    if (attempts === 1) {
      await redisClient.expire(`signup:${email}`, 3600);
    }
    
    if (attempts > 5) {
      throw new Error('Too many signup attempts');
    }
    
    await redisClient.quit();
    
    return event;
  } catch (error) {
    throw new Error(`reCAPTCHA verification failed: ${error.message}`);
  }
};