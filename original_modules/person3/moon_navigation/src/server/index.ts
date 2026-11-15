import { createApp } from "./app.js";

const port = Number(process.env.PORT ?? 3003);
createApp().listen(port, () => {
  console.log(`moon_navigation API listening on http://localhost:${port}/api/v1 (terrain: MOCK fixture)`);
});
