Para descargar fotos de `casareal.es`:

    > fetch.rb <start_id>

donde `<start_id>` es el id de la galeria de fotos más reciente en la web (119572 a principios de Mayo 2013 por ejemplo). El script recorrerá consecutivamente todas las galerías de fotos. Esto no es eficiente porque los ids no son consecutivos, sería mejor recorrer la lista de galerías, pero había que comprobarlo descargando al menos una vez todo.