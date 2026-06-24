const request = require('supertest');
const app = require('../src/app');

describe('GET /health', () => {
  it('returns 200 with status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('GET /items', () => {
  it('returns an array of items', async () => {
    const res = await request(app).get('/items');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});

describe('POST /items', () => {
  it('creates a new item', async () => {
    const res = await request(app)
      .post('/items')
      .send({ name: 'Widget C', qty: 3 });
    expect(res.statusCode).toBe(201);
    expect(res.body.name).toBe('Widget C');
  });

  it('returns 400 if name is missing', async () => {
    const res = await request(app)
      .post('/items')
      .send({ qty: 3 });
    expect(res.statusCode).toBe(400);
  });
});

describe('GET /items/:id', () => {
  it('returns 404 for unknown id', async () => {
    const res = await request(app).get('/items/999');
    expect(res.statusCode).toBe(404);
  });
});
