cd ../frontend-web
npm install

# Build for production
npm run build

# Test build
npm run preview

sudo nano /etc/nginx/sites-available/printflow

# Enable site
sudo ln -s /etc/nginx/sites-available/printflow /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Get SSL certificate
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d printflow.com -d api.printflow.com