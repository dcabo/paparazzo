Para descargar fotos de `casareal.es`:

    > fetch.rb <start_id>

donde `<start_id>` es el id de la galeria de fotos más reciente en la web (119572 a principios de Mayo 2013 por ejemplo). El script recorrerá consecutivamente todas las galerías de fotos. Esto no es eficiente porque los ids no son consecutivos, sería mejor recorrer la lista de galerías, pero había que comprobarlo descargando al menos una vez todo.

El script creará una carpeta 'data/', y un subdirectorio dentro de ésta para cada galería de fotos descargada. Se creará además en cada carpeta un fichero `metadata.csv` con los pies de foto y descripciones de las fotos. Para recopilar los metadatos de todas las galerías descargadas:

    > ./collect_metadata.sh

crerá un fichero `metadata.csv` global con los datos de todas las fotos descargadas.