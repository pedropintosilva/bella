# Bella: Makes your website out of ODF documents
The goal here is to have a nice way to generate and maintain a static website based solely on standardized OpenDocument format (ODF), currently just the ODT file extension.

* No JS
* Helps you with your new website (portfolio, blog)
* Allows to create pages, blog posts using LibreOffice or Collabora Online
* Updates your index page 

**To do: Move my personal content (website) from this repository or at least move it within some sort of "example" folder**
**To do: make possible to update homepage strings (contacts etc) without touching HTML**

Credits: image used for project example
* https://commons.wikimedia.org/wiki/File:Projet_de_machine_a%C3%A9rostatique_par_l%E2%80%99ing%C3%A9nieur_Leli%C3%A8vre_-_Archives_nationales-_F-12-2430.jpg
* 

## Motivation
Why do this? Well just for fun :) and because I myself would like to have an alternative workflow where:
* There is no need to rely on over complicated web frameworks
* I can keep using my favourite office suite to write my stuff while taking advantage of
  * Spellcheckers 
  * Thesaurus
  * AutoCorrect
  * Styles
  * Automatically have your webpages ready for offline consumption

# Structure
* public: generator folder to use in server 
* content: All content in odt
* static: Images and CSS


# Workflow
## Creating a Portfolio
### Add projects
1. Create a new odt file inside of `content/projects`
2. Write description and add images
3. Generate corresponding page `./generate.sh [odtfilenameWithoutextension]`
4. Update list of projects and correspondent homepage `./update-index.sh `

### Add top pages
1. Create a new odt file inside of `content/[newpage.odt]`
2. Write description and add images
3. Generate corresponding page `./generate-page.sh [newpage]` (without file extension)
4. Update homepage menu `./update-index.sh `

# How
Using python to get minimal results (without CSS) so we can have web content following website’s style-sheet and still be able to have document files with their own style.

## Installation Requirements 
1. Clone this repository or use the scripts
2. Install odf2xhtml (for example via pip using virtual environment)
* ``Create folder mkdir venv``
* ``Create environment python3 -m venv ./venv``
* ``Activate it source ./venv/bin/activate``
*  ``pip install odfpy``
  
