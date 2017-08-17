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
            data = JSON.stringify(pt.scene.toJSONEncodableObj())
            link = document.createElement("a")
            link.href = "data:text/plain,#{encodeURIComponent(data)}"
            link.download = "scene.json"
            document.body.appendChild(link)
            link.click()
            document.body.removeChild(link)
        )

        fileInput = document.createElement("input")
        fileInput.value = "Upload scene!"
        fileInput.type = "file"

        uploadButton = document.createElement("input")
        uploadButton.value = "Upload scene!"
        uploadButton.type = "button"
        uploadButton.addEventListener("click", =>
            fr = new FileReader()
            fr.onloadend = =>
                pt.loadScene(fr.result)
            fr.readAsText(fileInput.files[0])
        )

        document.body.appendChild(fileInput)
        document.body.appendChild(uploadButton)
        document.body.appendChild(document.createElement("br"))
        document.body.appendChild(renderButton)
        document.body.appendChild(downloadButton)
        document.body.appendChild(document.createElement("br"))
        document.body.appendChild(pt.getCanvas())


window.onload = ->
    app = new App()
    app.run()
