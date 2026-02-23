"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.optimizeGLB = optimizeGLB;
const gltf_pipeline_1 = require("gltf-pipeline");
async function optimizeGLB(glbBuffer) {
    try {
        console.log('Starting GLB optimization with Draco compression...');
        const options = {};
        const result = await (0, gltf_pipeline_1.processGlb)(glbBuffer, options);
        console.log('GLB optimization completed successfully');
        return Buffer.from(result.glb);
    }
    catch (error) {
        console.error('Error optimizing GLB:', error);
        throw new Error(`Failed to optimize GLB: ${error.message}`);
    }
}
//# sourceMappingURL=optimization.util.js.map