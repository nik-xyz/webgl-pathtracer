class App
    # Just testing code right now

    run: ->
        pt = new PathTracer()
        pt.setResolution(new Vec2(512, 512))

        window.render = ->
            pt.renderImage()
            pt.displayImage()

        renderButton = document.createElement("input")
        renderButton.value = "Render!"
        renderButton.type = "button"
        renderButton.addEventListener("click", render)

        downloadButton = document.createElement("input")
        downloadButton.value = "Download scene!"
        downloadButton.type = "button"
        downloadButton.addEventListener("click", =>
            @createDownload(JSON.stringify(pt.scene.toJSONEncodableObj()))
        )

        document.body.appendChild(renderButton)
        document.body.appendChild(downloadButton)
        document.body.appendChild(document.createElement("br"))
        document.body.appendChild(pt.getCanvas())


    createDownload: (data) ->
        link = document.createElement("a")
        link.href = "data:text/plain,#{encodeURIComponent(data)}"
        link.download = "scene.json"
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)


window.onload = ->
    app = new App()
    app.run()
