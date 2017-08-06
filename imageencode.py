import base64

if __name__ == "__main__":
    imagename = "img/Test.png"
    outname = "img/Test.js"

    with open(imagename, "rb") as imagefile:
        encoded = base64.b64encode(imagefile.read()).decode("ascii")

    with open(outname, "w") as outfile:
        outfile.write("var testImage = \"")
        outfile.write("data:image/png;base64,")
        outfile.write(encoded)
        outfile.write("\";")
