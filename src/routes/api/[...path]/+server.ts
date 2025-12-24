// src/routes/api/[...path]/+server.ts
import type { RequestHandler } from './$types';

const API_URL = process.env.PUBLIC_API_URL || 'http://127.0.0.1:8008';

async function forward(event: Parameters<RequestHandler>[0]) {
  const { request, url, params } = event;
  // Strip leading /api from frontend path and forward remainder to FastAPI
  const upstreamPath = url.pathname.replace(/^\/api/, '');
  const target = `${API_URL}${upstreamPath}${url.search}`;

  const headers = new Headers(request.headers);
  // Svelte adds some headers you don’t want to forward verbatim
  headers.delete('host');
  headers.delete('connection');

  const init: RequestInit = {
    method: request.method,
    headers,
    body: ['GET', 'HEAD'].includes(request.method) ? undefined : await request.arrayBuffer(),
    redirect: 'manual',
  };

  const resp = await fetch(target, init);
  return new Response(resp.body, {
    status: resp.status,
    statusText: resp.statusText,
    headers: resp.headers,
  });
}

export const GET: RequestHandler = forward;
export const POST: RequestHandler = forward;
export const PUT: RequestHandler = forward;
export const DELETE: RequestHandler = forward;
export const PATCH: RequestHandler = forward;