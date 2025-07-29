for file in *-Lab-*.md; do
    # Extrae la segunda línea después de "## Skills" y elimina el "- "
    new_title=$(sed -n '/## Skills/{n;n;s/^- //p;q}' "$file")

    # Reemplaza el contenido de title: "..." con el nuevo título
    sed -i "s|title: \".*\"|title: \"$new_title\"|" "$file"

    # Borra "## Skills" y las 3 líneas siguientes (4 líneas en total)
    sed -i '/## Skills/,+3d' "$file"
done
