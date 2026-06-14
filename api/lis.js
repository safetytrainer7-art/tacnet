// api/lis.js — LIS API Proxy for GitHub Serverless
// This uses your LIS_API_KEY stored as GitHub Secret

const LIS_API_KEY = process.env.LIS_API_KEY;

export default async function handler(req, res) {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    
    if (!LIS_API_KEY) {
        return res.status(500).json({ error: 'LIS_API_KEY environment variable not set. Add to GitHub Secrets.' });
    }
    
    const { type, query } = req.query;
    
    if (!query) {
        return res.status(400).json({ error: 'Missing query parameter' });
    }
    
    // LIS API endpoint (official DLAS endpoint)
    // Based on LIS documentation: https://lis.virginia.gov/api
    let lisEndpoint = '';
    switch(type) {
        case 'code':
            lisEndpoint = `https://api.lis.virginia.gov/v1/code/${encodeURIComponent(query)}`;
            break;
        case 'bill':
            lisEndpoint = `https://api.lis.virginia.gov/v1/bills/${query}`;
            break;
        case 'keyword':
            lisEndpoint = `https://api.lis.virginia.gov/v1/search?q=${encodeURIComponent(query)}`;
            break;
        default:
            return res.status(400).json({ error: 'Invalid query type' });
    }
    
    try {
        const response = await fetch(lisEndpoint, {
            headers: {
                'X-API-Key': LIS_API_KEY,
                'Accept': 'application/json',
                'User-Agent': 'TACNET-MultiAgency/1.0 (LEO Use Only)'
            }
        });
        
        if (!response.ok) {
            return res.status(response.status).json({ 
                error: `LIS API returned ${response.status}`,
                details: await response.text()
            });
        }
        
        const data = await response.json();
        return res.status(200).json(data);
        
    } catch (err) {
        return res.status(500).json({ error: `Proxy error: ${err.message}` });
    }
}
