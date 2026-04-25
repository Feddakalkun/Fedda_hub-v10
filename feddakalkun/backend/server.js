import cors from "cors";
import express from "express";
import fs from "node:fs/promises";
import path from "node:path";

const app = express();
const port = Number(process.env.FEDDA_BACKEND_PORT || 8000);
const repoRoot = path.resolve(process.cwd(), "..");
const workflowsDir = path.join(repoRoot, "backend", "workflows");
const comfyPort = Number(process.env.FEDDA_COMFY_PORT || 8188);
const comfyBaseUrl = process.env.FEDDA_COMFY_URL || `http://127.0.0.1:${comfyPort}`;

app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    service: "feddakalkun-backend",
    comfyBaseUrl,
  });
});

app.get("/api/system/comfy-status", async (_req, res) => {
  try {
    const response = await fetch(`${comfyBaseUrl}/system_stats`, {
      signal: AbortSignal.timeout(1500),
    });

    res.json({
      success: true,
      online: response.ok,
      statusCode: response.status,
      comfyBaseUrl,
    });
  } catch (error) {
    res.json({
      success: true,
      online: false,
      statusCode: null,
      comfyBaseUrl,
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

app.get("/api/workflow/list", async (_req, res) => {
  const workflows = [];

  async function walk(currentDir, relativeBase = "") {
    const entries = await fs.readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      const relativePath = path.join(relativeBase, entry.name);

      if (entry.isDirectory()) {
        await walk(fullPath, relativePath);
        continue;
      }

      if (!entry.isFile() || !entry.name.toLowerCase().endsWith(".json")) {
        continue;
      }

      workflows.push({
        id: relativePath.replace(/\\/g, "/"),
        name: entry.name,
        category: relativeBase ? relativeBase.replace(/\\/g, "/") : "root",
      });
    }
  }

  try {
    await walk(workflowsDir);
    workflows.sort((a, b) => a.id.localeCompare(b.id));
    res.json({ success: true, workflows });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

app.listen(port, "127.0.0.1", () => {
  console.log(`FEDDA backend listening on http://127.0.0.1:${port}`);
});
