# WebGL2 Pathtracer

A GPU path tracer implemented in GLSL using WebGL2, featuring

- A physically based rendering model.
- Support for arbitrary triangular geometry and materials.
- KD-tree scene partitioning.

With the introduction of WebGL2's `texelFetch()`, large data buffers can be made accessible to shaders by storing them in textures. This technique is used to make scene geometry data, material data, and acceleration structure data accessible to path tracing code running in a fragment shader. Theoretically, this allows complex scenes to be rendered, however in practice scene complexity is still limited several constraints such as the needing to prepare the data buffers in JavaScript code. Another limitation is that path tracing performance is typically limited by graphics memory bandwidth.

![Render output](render.png)
