class App
    run: ->
        rt = new RayTracer()
        rt.canvas.width = rt.canvas.height = 512
        document.body.appendChild(rt.canvas)

        rt.render()
        rt.render()


window.onload = ->
    app = new App()
    app.run()
