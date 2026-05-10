const AWS = require('aws-sdk');
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

const ses = new SESClient({ region: process.env.AWS_REGION });
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log('Email event received:', JSON.stringify(event, null, 2));
  
  for (const record of event.Records) {
    const message = JSON.parse(record.body);
    const { eventType, mail } = message;
    
    const emailId = mail.messageId;
    const recipient = mail.destination[0];
    
    // Store email event in DynamoDB
    const params = {
      TableName: process.env.EMAIL_EVENTS_TABLE,
      Item: {
        emailId,
        recipient,
        eventType,
        timestamp: new Date().toISOString(),
        metadata: message,
      },
    };
    
    await dynamodb.put(params).promise();
    
    // Update campaign analytics
    if (message.campaignId) {
      await updateCampaignStats(message.campaignId, eventType);
    }
    
    // Handle bounces and complaints
    if (eventType === 'Bounce') {
      await handleBounce(recipient, message.bounce);
    } else if (eventType === 'Complaint') {
      await handleComplaint(recipient, message.complaint);
    } else if (eventType === 'Delivery') {
      console.log(`Email delivered to ${recipient}`);
    } else if (eventType === 'Open') {
      await trackOpen(emailId, recipient, message.open);
    } else if (eventType === 'Click') {
      await trackClick(emailId, recipient, message.click);
    }
  }
  
  return { statusCode: 200 };
};

async function updateCampaignStats(campaignId, eventType) {
  const updateExpression = {
    'Delivery': 'totalDelivered',
    'Open': 'totalOpened',
    'Click': 'totalClicked',
    'Bounce': 'totalBounced',
    'Complaint': 'totalComplained',
  };
  
  const params = {
    TableName: process.env.CAMPAIGNS_TABLE,
    Key: { id: campaignId },
    UpdateExpression: `ADD ${updateExpression[eventType]} :inc`,
    ExpressionAttributeValues: { ':inc': 1 },
  };
  
  await dynamodb.update(params).promise();
}

async function handleBounce(recipient, bounce) {
  console.log(`Bounce for ${recipient}: ${bounce.bounceType}`);
  
  // Add to suppression list
  const params = {
    TableName: process.env.SUPPRESSION_TABLE,
    Item: {
      email: recipient,
      reason: bounce.bounceType,
      timestamp: new Date().toISOString(),
    },
  };
  
  await dynamodb.put(params).promise();
}

async function handleComplaint(recipient, complaint) {
  console.log(`Complaint for ${recipient}: ${complaint.complaintFeedbackType}`);
  
  // Add to suppression list
  const params = {
    TableName: process.env.SUPPRESSION_TABLE,
    Item: {
      email: recipient,
      reason: 'complaint',
      timestamp: new Date().toISOString(),
    },
  };
  
  await dynamodb.put(params).promise();
}

async function trackOpen(emailId, recipient, openData) {
  console.log(`Email opened: ${emailId} by ${recipient} at ${openData.timestamp}`);
}

async function trackClick(emailId, recipient, clickData) {
  console.log(`Email clicked: ${emailId} by ${recipient} on ${clickData.link}`);
}