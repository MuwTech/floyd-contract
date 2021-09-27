const fs = require('fs');
const args = process.argv.slice(2);
const baseAssetsDir = `../base_assets/${args[0]}`;
const metadataDir = `./generated_metadata/test`;
const imageProperties = require(baseAssetsDir + "/imageProperties.json");
const startingIndex = args[1];
const totalImages = Object.keys(imageProperties).length;

if (fs.existsSync(metadataDir)) {
    fs.rmdirSync(metadataDir, { recursive: true })
}
fs.mkdirSync(metadataDir, { recursive: true });
console.log(imageProperties)
Object.keys(imageProperties).forEach(key => {
    const imageProperty = imageProperties[key]
    const initialSequenceIndex = (startingIndex + imageProperty.tokenId) % totalImages
    const metadataJSON = {
        description: `FruitPic: ${imageProperty.name}`,
        image: `ipfs://${imageProperty.hash.tokenId}`, 
        //ipfs://<folder_hash>/<token_id>

        name: imageProperty.name
    }
    console.log(metadataJSON);
    fs.writeFileSync(`${metadataDir}/${initialSequenceIndex}`, JSON.stringify(metadataJSON, 4, 2))
});


