const nodemailer = require('nodemailer');

// Create transporter
const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Send verification PIN email
const sendVerificationPinEmail = async (userEmail, username, pin) => {
    try {
        await transporter.sendMail({
            from: process.env.EMAIL_FROM,
            to: userEmail,
            subject: "Your Todo App Verification Code",
            html: `
                <h1>Welcome to Todo App, ${username}!</h1>
                <p>Thank you for registering. Please use the following verification code to complete your registration:</p>
                <div style="background-color: #f4f4f4; padding: 15px; margin: 20px 0; text-align: center; font-size: 24px; letter-spacing: 5px; font-family: monospace;">
                    <strong>${pin}</strong>
                </div>
                <p>This verification code will expire in 15 minutes.</p>
                <p>If you didn't create an account, please ignore this email.</p>
                <p>Note: For security reasons, never share this code with anyone.</p>
            `
        });
    } catch (error) {
        console.error('Error sending verification PIN email:', error);
        throw error;
    }
};

// Send welcome email
const sendWelcomeEmail = async (userEmail, username) => {
    try {
        await transporter.sendMail({
            from: process.env.EMAIL_FROM,
            to: userEmail,
            subject: "Welcome to Todo-App!",
            html: `
                <h1>Welcome to Todo-App, ${username}!</h1>
                <p>Thank you for verifying your email. Your account is now fully activated!</p>
                <p>You can now:</p>
                <ul>
                    <li>Add your tasks</li>
                    <li>Edit your tasks</li>
                    <li>Delete your tasks</li>
                </ul>
                <p>Happy reading!</p>
            `
        });
    } catch (error) {
        console.error('Error sending welcome email:', error);
        // Don't throw the error as welcome email should not block the process
    }
};

// Send password reset email
const sendPasswordResetEmail = async (userEmail, resetToken) => {
    try {
        await transporter.sendMail({
            from: process.env.EMAIL_FROM,
            to: userEmail,
            subject: "Password Reset Request",
            html: `
                <h1>Password Reset Request</h1>
                <p>You requested to reset your password. Please use the following token to reset your password:</p>
                <p><strong>${resetToken}</strong></p>
                <p>This token will expire in 1 hour.</p>
                <p>If you didn't request this, please ignore this email.</p>
            `
        });
    } catch (error) {
        console.error('Error sending password reset email:', error);
        throw error;
    }
};

// Send reset PIN email
const sendResetPinEmail = async (userEmail, username, pin) => {
    try {
        await transporter.sendMail({
            from: process.env.EMAIL_FROM,
            to: userEmail,
            subject: 'Reset Your Password',
            html: `
                <h1>Hello ${username}!</h1>
                <p>You requested to reset your password.</p>
                <p>Your password reset PIN is: <strong>${pin}</strong></p>
                <p>This PIN will expire in 15 minutes.</p>
                <p>If you didn't request this password reset, please ignore this email.</p>
            `
        });
    } catch (error) {
        console.error('Error sending reset PIN email:', error);
        throw error;
    }
};

module.exports = {
    sendVerificationPinEmail,
    sendWelcomeEmail,
    sendPasswordResetEmail,
    sendResetPinEmail
};
