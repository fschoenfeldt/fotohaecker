import { FullConfig } from "@playwright/test";
import { spawn } from "child_process";

async function globalTeardown(config: FullConfig) {
    const child = spawn('mix content delete orphaned -y', {
        shell: true,
        cwd: '../../'
    });

    await new Promise((resolve, reject) => {
        child.on('close', (code: number) => {
            if (code === 0) {
                resolve(0);
            } else {
                reject(new Error(`Command failed with code ${code}`));
            }
        });
    });
}

export default globalTeardown;