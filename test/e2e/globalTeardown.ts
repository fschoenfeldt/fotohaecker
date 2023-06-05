import { FullConfig } from "@playwright/test";
import { spawn } from "child_process";

async function globalTeardown(config: FullConfig) {
  if process.env.CI {
    return;
  }
  const orphaned = await deleteOrphanedPhotoFiles(config);
  const reset = await resetDatabase(config);

  return Promise.all([orphaned, reset]);
}

async function deleteOrphanedPhotoFiles(config: FullConfig) {
  return runCLICommand("mix content delete orphaned -y");
}

async function resetDatabase(config: FullConfig) {
  return runCLICommand("MIX_ENV=e2e mix ecto.reset");
}

async function runCLICommand(command: String) {
  const child = spawn(command, {
    shell: true,
    cwd: "../../",
  });

  return new Promise((resolve, reject) => {
    child.on("close", (code: number) => {
      if (code === 0) {
        resolve(0);
      } else {
        reject(new Error(`Command ${command} failed with code ${code}`));
      }
    });
  });
}

export default globalTeardown;
