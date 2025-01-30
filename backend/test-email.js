require('dotenv').config();
const nodemailer = require('nodemailer');

// Create transporter
const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false, // true for 465, false for other ports
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Test email function
async function sendTestEmail() {
    try {
        // Send mail with defined transport object
        const info = await transporter.sendMail({
            from: process.env.EMAIL_FROM,
            to: "test@example.com", // Change this to your test recipient email
            subject: "Test Email from Book Store App",
            text: "Hello! This is a test email from your Book Store application.",
            html: "<b>Hello!</b><br>This is a test email from your Book Store application."
        });

        console.log("Message sent successfully!");
        console.log("Message ID:", info.messageId);
    } catch (error) {
        console.error("Error sending email:", error);
    }
}

// Run the test
sendTestEmail();
