declare module 'gltf-pipeline' {
  export function processGlb(
    glb: Buffer,
    options?: Record<string, unknown>,
  ): Promise<{ glb: Uint8Array | Buffer }>;
}
