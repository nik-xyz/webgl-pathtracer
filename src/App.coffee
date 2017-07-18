class App
    run: ->
        pt = new PathTracer()
        pt.setResolution(new Vec2(512, 512))

        render = ->
            pt.renderImage()
            pt.displayImage()

        button = document.createElement("input")
        button.value = "Render!"
        button.type = "button"
        button.addEventListener("click", render)

        document.body.appendChild(button)
        document.body.appendChild(document.createElement("br"))
        document.body.appendChild(pt.canvas)

window.onload = ->
    app = new App()
    app.run()
