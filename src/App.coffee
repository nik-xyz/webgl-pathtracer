class App
    run: ->
        rt = new RayTracer()
        document.body.appendChild(rt.canvas)

        rt.render()


window.onload = ->
    app = new App()
    app.run()
