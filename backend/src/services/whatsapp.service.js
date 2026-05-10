const twilio = require('twilio');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhone = process.env.TWILIO_WHATSAPP_NUMBER;

const client = twilio(accountSid, authToken);

async function sendEReceiptWhatsApp(orderId) {
  try {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        user: true,
        driver: { include: { user: true } },
        deliveries: { orderBy: { completedAt: 'desc' }, take: 1 }
      }
    });
    
    if (!order || !order.user.phone) return;
    
    // Format phone number (remove 0, add +62)
    let phoneNumber = order.user.phone;
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '+62' + phoneNumber.substring(1);
    } else if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+62' + phoneNumber;
    }
    
    // Generate E-Receipt HTML/Text
    const receiptMessage = generateReceiptMessage(order);
    
    // Send via Twilio WhatsApp
    const message = await client.messages.create({
      body: receiptMessage,
      from: `whatsapp:${twilioPhone}`,
      to: `whatsapp:${phoneNumber}`,
      mediaUrl: order.deliveryPhoto ? [order.deliveryPhoto] : undefined
    });
    
    // Save receipt record
    await prisma.receipt.create({
      data: {
        orderId: order.id,
        type: 'WHATSAPP',
        recipient: phoneNumber,
        messageId: message.sid,
        status: message.status,
        content: receiptMessage,
        sentAt: new Date()
      }
    });
    
    console.log(`📱 E-Receipt sent to ${phoneNumber}, SID: ${message.sid}`);
    return message;
    
  } catch (error) {
    console.error('WhatsApp send error:', error);
    throw error;
  }
}

function generateReceiptMessage(order) {
  const date = new Date(order.deliveredAt || order.createdAt);
  const formattedDate = date.toLocaleDateString('id-ID', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
  
  return `
*📄 PRINTFLOW E-RECEIPT*

Terima kasih telah menggunakan layanan PrintFlow!

━━━━━━━━━━━━━━━━━━━━
*ORDER DETAILS*
━━━━━━━━━━━━━━━━━━━━
Order ID: ${order.id.substring(0,12)}...
Tanggal: ${formattedDate}
File: ${order.fileName}
Jumlah: ${order.pages} halaman x ${order.copies} copy
Metode: ${order.paymentMethod === 'COD' ? 'Bayar di Tempat (COD)' : 'Transfer Bank'}

━━━━━━━━━━━━━━━━━━━━
*PEMBAYARAN*
━━━━━━━━━━━━━━━━━━━━
Total: Rp ${order.totalPrice.toLocaleString()}
Status: ${order.paymentStatus === 'PAID' ? '✅ LUNAS' : '⏳ PENDING'}

━━━━━━━━━━━━━━━━━━━━
*PENGIRIMAN*
━━━━━━━━━━━━━━━━━━━━
Driver: ${order.driver?.user.name || '-'}
Metode: ${order.deliveryMethod === 'COURIER_COD' ? 'Kurir COD' : 'Ambil di Hub Point'}

${order.deliveryMethod === 'HUB_POINT' ? `
📍 *Lokasi Ambil:*
${order.hubPoint?.address || 'Hub Point terdekat'}

Silakan ambil pesanan di lokasi tersebut dengan menunjukkan pesan ini.
` : ''}

━━━━━━━━━━━━━━━━━━━━
*BUTUH BANTUAN?*
━━━━━━━━━━━━━━━━━━━━
Hubungi CS: 0812-3456-7890
Email: cs@printflow.com

*Simpan pesan ini sebagai bukti transaksi Anda*

Terima kasih! 🙏
  `.trim();
}

// Send bulk WhatsApp (for school/office hub)
async function sendBulkReceipts(orders) {
  const results = [];
  for (const order of orders) {
    try {
      const result = await sendEReceiptWhatsApp(order.id);
      results.push({ orderId: order.id, success: true, messageId: result?.sid });
      await delay(1000); // Rate limiting
    } catch (error) {
      results.push({ orderId: order.id, success: false, error: error.message });
    }
  }
  return results;
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = { sendEReceiptWhatsApp, sendBulkReceipts };