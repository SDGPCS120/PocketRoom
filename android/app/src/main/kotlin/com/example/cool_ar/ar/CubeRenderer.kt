package com.example.cool_ar.ar

import android.opengl.GLES20
import android.opengl.Matrix
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import java.nio.ShortBuffer

/**
 * Renders a colored cube using OpenGL ES 2.0.
 *
 * A minimal renderer with flat shading — no textures, no lighting.
 * Sufficient for Phase 1 proof of concept. Later phases will replace
 * this with GLB model loading (Filament or SceneView).
 */
class CubeRenderer {

    private val program: Int
    private val vertexBuffer: FloatBuffer
    private val indexBuffer: ShortBuffer

    companion object {
        private const val VERTEX_SHADER = """
            uniform mat4 u_MVP;
            attribute vec4 a_Position;
            void main() {
                gl_Position = u_MVP * a_Position;
            }
        """

        private const val FRAGMENT_SHADER = """
            precision mediump float;
            uniform vec4 u_Color;
            void main() {
                gl_FragColor = u_Color;
            }
        """

        // Unit cube vertices centered at origin (±0.5)
        private val VERTICES = floatArrayOf(
            // Front face
            -0.5f, -0.5f,  0.5f,
             0.5f, -0.5f,  0.5f,
             0.5f,  0.5f,  0.5f,
            -0.5f,  0.5f,  0.5f,
            // Back face
            -0.5f, -0.5f, -0.5f,
             0.5f, -0.5f, -0.5f,
             0.5f,  0.5f, -0.5f,
            -0.5f,  0.5f, -0.5f,
        )

        // Triangle indices for 6 faces (12 triangles)
        private val INDICES = shortArrayOf(
            0, 1, 2, 0, 2, 3, // front
            1, 5, 6, 1, 6, 2, // right
            5, 4, 7, 5, 7, 6, // back
            4, 0, 3, 4, 3, 7, // left
            3, 2, 6, 3, 6, 7, // top
            4, 5, 1, 4, 1, 0, // bottom
        )
    }

    init {
        vertexBuffer = ByteBuffer.allocateDirect(VERTICES.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .apply {
                put(VERTICES)
                position(0)
            }

        indexBuffer = ByteBuffer.allocateDirect(INDICES.size * 2)
            .order(ByteOrder.nativeOrder())
            .asShortBuffer()
            .apply {
                put(INDICES)
                position(0)
            }

        program = createProgram(VERTEX_SHADER, FRAGMENT_SHADER)
    }

    /**
     * Draws a cube with the given transforms and color.
     *
     * @param modelMatrix   4x4 model matrix from the anchor pose
     * @param viewMatrix    4x4 view matrix from the camera
     * @param projMatrix    4x4 projection matrix from the camera
     * @param color         RGBA color (each 0.0–1.0)
     * @param size          Cube edge length in meters
     */
    fun draw(
        modelMatrix: FloatArray,
        viewMatrix: FloatArray,
        projMatrix: FloatArray,
        color: FloatArray,
        size: Float,
    ) {
        // Scale the model matrix by cube size
        val scaledModel = FloatArray(16)
        Matrix.setIdentityM(scaledModel, 0)
        Matrix.scaleM(scaledModel, 0, size, size, size)

        val finalModel = FloatArray(16)
        Matrix.multiplyMM(finalModel, 0, modelMatrix, 0, scaledModel, 0)

        // MVP = projection × view × model
        val mvMatrix = FloatArray(16)
        Matrix.multiplyMM(mvMatrix, 0, viewMatrix, 0, finalModel, 0)
        val mvpMatrix = FloatArray(16)
        Matrix.multiplyMM(mvpMatrix, 0, projMatrix, 0, mvMatrix, 0)

        GLES20.glUseProgram(program)

        val mvpHandle = GLES20.glGetUniformLocation(program, "u_MVP")
        val colorHandle = GLES20.glGetUniformLocation(program, "u_Color")
        val positionHandle = GLES20.glGetAttribLocation(program, "a_Position")

        GLES20.glUniformMatrix4fv(mvpHandle, 1, false, mvpMatrix, 0)
        GLES20.glUniform4fv(colorHandle, 1, color, 0)

        GLES20.glEnableVertexAttribArray(positionHandle)
        GLES20.glVertexAttribPointer(positionHandle, 3, GLES20.GL_FLOAT, false, 0, vertexBuffer)

        GLES20.glDrawElements(
            GLES20.GL_TRIANGLES,
            INDICES.size,
            GLES20.GL_UNSIGNED_SHORT,
            indexBuffer,
        )

        GLES20.glDisableVertexAttribArray(positionHandle)
    }

    private fun createProgram(vertexSource: String, fragmentSource: String): Int {
        val vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexSource)
        val fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentSource)
        val prog = GLES20.glCreateProgram()
        GLES20.glAttachShader(prog, vertexShader)
        GLES20.glAttachShader(prog, fragmentShader)
        GLES20.glLinkProgram(prog)
        return prog
    }

    private fun loadShader(type: Int, source: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)
        return shader
    }
}
