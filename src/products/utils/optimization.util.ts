import { processGlb } from 'gltf-pipeline';

/**
 Optimizes a GLB buffer using Draco compression
 @param glbBuffer - The raw GLB buffer to optimize
 @returns Promise<Buffer> - The optimized GLB buffer
 */
export async function optimizeGLB(glbBuffer: Buffer): Promise<Buffer> {
  try {
    console.log('Starting GLB optimization with Draco compression...');

<<<<<<< HEAD
        const options = {
            dracoOptions: {
                compressionLevel: 7,
            },
        };
=======
    const options = {
      // dracoOptions: {
      //     compressionLevel: 7, // Level 7 compression
      // },
    };
>>>>>>> d736028ecd9905450b5fd998b5f70e76ff4eef59

    const result = await processGlb(glbBuffer, options);

    console.log('GLB optimization completed successfully');
    return Buffer.from(result.glb);
  } catch (error) {
    console.error('Error optimizing GLB:', error);
    throw new Error(`Failed to optimize GLB: ${error.message}`);
  }
}
