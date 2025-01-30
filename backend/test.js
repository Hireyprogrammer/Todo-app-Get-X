const axios = require('axios');

async function testAPI() {
    try {
        // 1. Login to get token
        console.log('\n1. Attempting login...');
        const loginResponse = await axios.post('http://localhost:9000/api/auth/login', {
            email: 'hireyprogrammer10@gmail.com',
            password: 'Maxamuud11@'
        });
        
        const { token, user } = loginResponse.data;
        console.log('\nLogin successful!');
        console.log('User:', user);
        console.log('Token received (first 50 chars):', token.substring(0, 50) + '...');
        
        // 2. Create a task list
        console.log('\n2. Creating task list...');
        const taskListData = {
            name: "Work Tasks",
            listType: "WORK",
            description: "My work related tasks",
            color: "#FF6B6B",
            customIcon: "computer"
        };
        console.log('Task list data:', taskListData);
        
        const config = {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        };
        console.log('Request headers:', config.headers);
        
        const taskListResponse = await axios.post(
            'http://localhost:9000/api/tasklists',
            taskListData,
            config
        );
        
        console.log('\nTask list created successfully:', taskListResponse.data);
        
        // 3. Get all task lists
        console.log('\n3. Getting all task lists...');
        const getListsResponse = await axios.get('http://localhost:9000/api/tasklists', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        
        console.log('\nAll task lists:', getListsResponse.data);
        
    } catch (error) {
        console.error('\nError occurred:');
        if (error.response) {
            console.error('Response data:', error.response.data);
            console.error('Response status:', error.response.status);
            console.error('Response headers:', error.response.headers);
        } else if (error.request) {
            console.error('No response received:', error.request);
        } else {
            console.error('Error message:', error.message);
        }
    }
}

testAPI();
