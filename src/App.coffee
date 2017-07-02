class App
    run: ->
        rt = new RayTracer()
        rt.canvas.width = rt.canvas.height = 1000
        document.body.appendChild(rt.canvas)

        rt.render()

window.onload = ->
    app = new App()
    app.run()
