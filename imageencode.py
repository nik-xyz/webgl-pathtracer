import base64

if __name__ == "__main__":
    imagename = "img/Test{}.png"
    outname = "img/Test.js"


    with open(outname, "w") as outfile:
        for i in range(2):
            with open(imagename.format(i), "rb") as imagefile:
                encoded = base64.b64encode(imagefile.read()).decode("ascii")

            outfile.write("var testImage{} = \"".format(i))
            outfile.write("data:image/png;base64,")
            outfile.write(encoded)
            outfile.write("\";\n")
