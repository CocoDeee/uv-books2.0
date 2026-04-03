# uv-books 2.0
### A FiveM Resource by CocoDeee (Alias ☽⋆Ξᑢᕼ𐍈⋆☾)
**Developer & Owner — Uncanny Valley RP**
 
**Discord For Uncanny Valley: https://discord.gg/xHhGMqSeFZ Please let me know if you have any issues or need help! We are more than just an RP server we are a community**
 
*If you use this resource, a credit or a star on the repo is always appreciated but never required. Enjoy!*

## After Downloading: Remove the 2.0 from the folder name
 
---
 
## What Is This?
 
uv-books 2.0 is a complete overhaul of my original in-game book writing and reading system for FiveM. Version 1 worked, but I wasn't happy with it — the UI felt flat, it lacked features I kept wishing it had, and it didn't do justice to the idea I had in my head. So I rebuilt it from the ground up.
 
Version 2.0 brings a brand new 3D page-flipping UI, the ability to add images to pages, 12 font choices, genre tagging, draft saving so you don't have to write everything in one sitting, and a 1-for-1 book swap system that gives blank books real value. Bug fixes across multi-framework compatibility are included as well.
 
Players can pick up a blank book item, write their own multi-page book, add images, choose a font, tag it with a genre, sign it (or publish anonymously), and keep that finished book as a unique item in their inventory — with every word, image, and style choice saved permanently.
 
Other players can pick up that book and read it, flipping through pages with animated 3D page turns, exactly as it was written.
 
---
 
## What's New in 2.0
 
- **New 3D page-flip UI** — completely rebuilt from scratch with realistic CSS 3D page turns, leather cover textures, and aged paper
- **Images on pages** — paste a URL, drag and resize freely
- **12 font choices** — from classic serif to typewriter, handwritten, futuristic, and more
- **Genre tagging** — 15 presets plus custom input, displays in inventory tooltip
- **Save & Close drafts** — pick up where you left off, progress saved to the item
- **1-for-1 book swap** — publishing replaces the blank book, giving them real value
- **Multi-framework bug fixes** — improved compatibility across QBCore, QBox, and multiple inventory systems
- **New cover art and inventory image**
 
---
 
## Supported Frameworks & Inventories
 
**Frameworks:**
- QBCore
- QBox (qbx_core)
 
**Inventories:**
- ox_inventory
- qb-inventory
- qs-inventory
- ps-inventory
- lj-inventory
- jaksam_inventory
 
The script auto-detects your framework and inventory on startup. No config needed.
 
---
 
## Features
 
- **3D Page-Flip Book UI** — A realistic book with animated CSS 3D page turns. Front and back covers with custom textures, easy on the eyes paper pages, spine detail. Click pages to flip in reader mode, use navigation buttons in writer mode.
 
- **Write a Book** — Use a blank `book` item to open the writer. Write across up to 20 pages, each holding up to 800 characters. Live character counter and page dot indicators show your progress.
 
- **Save & Close Drafts** — Don't have to write it all in one sitting! Hit "Save & Close" to save your progress (title, pages, images, font) to the item. Pick it back up later and continue right where you left off.
 
- **Images on Pages** — Paste any image URL (Imgur, etc.) onto a page. Drag it anywhere, resize it with the corner handle, delete it if you don't like it. Images persist to the published book and display in the reader.
 
- **12 Font Choices** — Pick a font on the cover page before writing. Applies to the title and all page content. Choices range from classic serif to handwritten, typewriter, script, futuristic, and more. Font is saved with the book and renders in the reader.
 
- **Genre Tag** — Select a genre when publishing (Fiction, Mystery, Horror, Romance, Fantasy, Sci-Fi, and more) or type a custom one. Genre displays in the inventory tooltip on hover.
 
- **Sign or Publish Anonymously** — Choose to sign with any name or leave the author as "Unknown."
 
- **1-for-1 Book Swap** — Publishing consumes the blank/draft book and replaces it with the finished version. Players need to acquire more blank books to write more — gives blank books real value.
 
- **Read Any Published Book** — Click to flip through pages with 3D page-turn animations. Title page spread shows the book title and author. Images and fonts render exactly as the writer intended.
 
---
 
## Character Limits
 
| Field | Max Characters |
|-------|---------------|
| Book Title | 20 |
| Author Name | 15 |
| Page Content | 800 per page |
| Custom Genre | 30 |
 
---
 
## Installation

## After Downloading: Remove the 2.0 from the folder name
 
### 1. Add the resource
Drop the `uv-books` folder into your server's `resources` directory.
 
Add the following to your `server.cfg`:
```
ensure uv-books
```
 
### 2. Add the item definition
 
**QBCore** (`qb-core/shared/items.lua`):
```lua
['book'] = {['name'] = 'book', ['label'] = 'Book', ['weight'] = 250, ['type'] = 'item', ['image'] = 'book.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A blank book, waiting to be written in.'},
```
 
**QBox / ox_inventory** (`ox_inventory/data/items.lua`):
```lua
['book'] = {
    label = 'Book',
    weight = 200,
    stack = false,
    close = true,
    consume = 0,
    server = {
        export = 'uv-books.book'
    }
},
```
 
### 3. Add the item image
Place `book.png` into your inventory's image folder:
 
| Inventory | Path |
|-----------|------|
| qb-inventory | `qb-inventory/html/images/` |
| ox_inventory | `ox_inventory/web/images/` |
| qs-inventory | `qs-inventory/html/images/` |
| ps-inventory | `ps-inventory/html/images/` |
| lj-inventory | `lj-inventory/html/images/` |
 
The new image (updated from V1) is included in the `images` folder of this resource.
 
### 4. Give players blank books
Via server console or tie it to a shop/crafting system:
```
/giveitem [playerid] book 1
```
 
---
 
## Inventory Tooltip Setup (Genre Display)
 
By default, most inventories won't know to show the genre field in the book tooltip. Here's how to add it for each inventory:
 
### qs-inventory
 
Find the book tooltip section in your qs-inventory JavaScript (usually in `qs-inventory/config/metadata.js` — search for `itemData.name == "book"`). Replace the existing book block with:
 
```javascript
if (itemData.name == "book" && itemData.info.title) {
    const info = itemData.info || {};
    const title = info.title || label || 'Book';
    const author = info.author || 'Unknown';
    const genre = info.genre || '';
 
    $(".item-info-title").html(`<p>${title}</p>`);
 
    const rows = [
        `<p><strong>Title: </strong><span>${title}</span></p>`,
        `<p><strong>Author: </strong><span>${author}</span></p>`,
    ];
    if (genre) {
        rows.push(`<p><strong>Genre: </strong><span>${genre}</span></p>`);
    }
    $(".item-info-description").html(rows.join(''));
}
```
 
### qb-inventory
 
Find the tooltip section in `qb-inventory/html/js/app.js` — search for `"book"` in the item info display logic. Add a similar block:
 
```javascript
if (itemData.name == "book" && itemData.info.title) {
    const info = itemData.info || {};
    const title = info.title || label || 'Book';
    const author = info.author || 'Unknown';
    const genre = info.genre || '';
 
    $(".item-info-title").html(`<p>${title}</p>`);
 
    const rows = [
        `<p><strong>Title: </strong><span>${title}</span></p>`,
        `<p><strong>Author: </strong><span>${author}</span></p>`,
    ];
    if (genre) {
        rows.push(`<p><strong>Genre: </strong><span>${genre}</span></p>`);
    }
    $(".item-info-description").html(rows.join(''));
}
```
 
### ox_inventory
 
ox_inventory reads the `description` field from item metadata automatically. uv-books already sets this — no extra setup needed. The tooltip will show something like: `"My Book" by John Smith · Fantasy`
 
---
 
## Font Choices
 
The writer includes 12 font options on the cover page:
 
| Font | Style |
|------|-------|
| Classic Serif | Traditional book feel (Palatino Linotype) |
| Merriweather | Elegant serif |
| Cinzel | Formal / engraved |
| Modern Sans | Clean modern (Lato) |
| Zilla Slab | Sturdy slab serif |
| Script | Flowing calligraphy (Great Vibes) |
| Dancing Script | Playful script |
| Handwritten | Casual handwriting (Caveat) |
| Indie | Quirky hand-drawn (Indie Flower) |
| Typewriter | Old typewriter (Special Elite) |
| Futuristic | Sci-fi / tech (Orbitron) |
| Tech | Sleek modern (Rajdhani) |
 
The selected font applies to the book title and all page content in both the writer and reader. (It will update the title page after selecting a font and publishing-trust)
 
---
 
## Genre Options
 
Available genres when publishing: Fiction, Non-Fiction, Mystery, Horror, Romance, Adventure, Fantasy, Sci-Fi, History, Comedy, Drama, Poetry, Journal, Guide, or a custom genre of your choice.
 
---
 
## Images on Pages
 
Players can add images to any page by clicking the picture icon in the top-right corner of a page. Paste an image URL (Imgur direct links recommended — Discord CDN links expire) and the image appears on the page. Drag it anywhere, resize with the corner handle, or delete it. Beware- it does cover text if the image is placed atop your writing
 
Images are stored as URLs in the item metadata, keeping data lightweight. They render at the same position and size in the reader.
 
**Note:** Discord CDN links expire after some time!! For permanent images, use direct links
 
---
 
## How It Works
 
Every `book` item in the game shares the same base item, but carries unique metadata that determines its behavior:
 
- **Blank book** (no metadata) → opens the writer
- **Draft book** (has `draft` in metadata) → opens the writer with saved progress loaded
- **Published book** (has `content` in metadata) → opens the reader
 
Publishing consumes the blank/draft book and replaces it with a published copy. Two books can look identical in your inventory but contain completely different stories, images, fonts, and genres.
 
---
 
## Dependencies
 
- [QBCore Framework](https://github.com/qbcore-framework/qb-core) or [QBox](https://github.com/Qbox-project/qbx_core)
- A compatible inventory resource (qb-inventory, ox_inventory, qs-inventory, ps-inventory, lj-inventory, jaksam_inventory)
 
---
 
## Planned Features Still In The Works
 
- 🖨️ **Printing Press Script** — A companion resource featuring an NPC printing press operator who can make copies of any published book for an in game fee. The NPC will be fully placeable at any `vec4` coordinate of your choosing on your server.
- 🗺️ More to come as Uncanny Valley RP grows, feel free to join the community there's more than just RP: https://discord.gg/xHhGMqSeFZ
 
---
 
## Folder Structure
 
```
uv-books/
├── fxmanifest.lua
├── client.lua
├── server.lua
├── README.md
├── LICENSE
├── images/
│   └── book.png
└── html/
    ├── index.html
    ├── uvbookfront.jpg
    ├── uvbookback.jpg
    └── uvbookpage.jpg
```
 
---
 
## Notes
 
- Books are **unique items** — each published book is its own instance with its own content, images, font, and genre
- The blank book item and the published book are the same `book` item — the script detects what's stored and opens the writer or reader accordingly
- Signing a book is optional — unsigned books display as written by "Unknown"
- Draft saves persist across sessions — players can close the game and come back to their draft
- Image URLs are stored in item metadata — use permanent hosts
 
---
 
## Acknowledgements
 
Huge thank you to **boii.dev** for giving me permission to use their guidebook from boii-farming as inspiration for the 3D page-flip UI. Their work showed me that page flipping was possible in FiveM NUI and gave me a foundation to build on.
 
---
 
## Extras
 
Feel free to modify, change, or improve the source code. Please do not remove my name, and do not sell this script. See LICENSE.
 
## Credits
 
Created by **CocoDeee** (Alias ☽⋆Ξᑢᕼ𐍈⋆☾)
Developer & Owner of **Uncanny Valley RP**
