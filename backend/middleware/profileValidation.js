const validateProfile = (req, res, next) => {
  const { firstName, lastName, bio, phoneNumber, address } = req.body;

  // Validate name lengths
  if (firstName && (firstName.length < 2 || firstName.length > 50)) {
    return res.status(400).json({ message: 'First name must be between 2 and 50 characters' });
  }

  if (lastName && (lastName.length < 2 || lastName.length > 50)) {
    return res.status(400).json({ message: 'Last name must be between 2 and 50 characters' });
  }

  // Validate bio length
  if (bio && bio.length > 500) {
    return res.status(400).json({ message: 'Bio cannot exceed 500 characters' });
  }

  // Validate phone number (optional but strict if provided)
  if (phoneNumber) {
    const phoneRegex = /^(\+\d{1,3}[- ]?)?\d{10}$/;
    if (!phoneRegex.test(phoneNumber)) {
      return res.status(400).json({ message: 'Invalid phone number format' });
    }
  }

  // Validate address fields if provided
  if (address) {
    const addressFields = ['street', 'city', 'state', 'country', 'zipCode'];
    addressFields.forEach(field => {
      if (address[field] && (address[field].length < 2 || address[field].length > 100)) {
        return res.status(400).json({ message: `${field} must be between 2 and 100 characters` });
      }
    });
  }

  next();
};

module.exports = validateProfile;
