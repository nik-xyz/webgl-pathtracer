class App
    run: ->
        pt = new PathTracer()
        pt.canvas.width = pt.canvas.height = 1000
        document.body.appendChild(pt.canvas)

        pt.render()

window.onload = ->
    app = new App()
    app.run()
