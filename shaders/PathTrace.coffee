ShaderSources.getPathTraceSource = -> """
const uint BOUNCES = 5u;

vec3 tracePath(Ray ray) {
    vec3 incomingLight = vec3(0.0);
    vec3 colorFilter = vec3(1.0);

    for(uint bounce = 0u; bounce < BOUNCES; bounce++) {
        SceneHitTestResult res = hitTestScene(ray);

        if(res.hit) {
            // TODO: get color from texture & material
            colorFilter *= vec3(res.tex.y, res.tex.y, 1.0);

            // TODO: get emissivity from material
            vec3 emission = vec3(0.0);

            incomingLight += colorFilter * emission;

            vec3 dir = reflect(ray.dir, res.nor);
            ray = createRay(res.pos + dir * 0.001, dir);
        }
        else {
            // TODO: sample background enviroment map instead
            incomingLight += colorFilter * vec3(ray.dir.yyy + 0.3);
            break;
        }
    }

    return incomingLight;
}


"""
