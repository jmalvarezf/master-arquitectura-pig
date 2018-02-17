
/* 1.Carga el fichero de los posts forum_node.tsv, utilizando una extension de Piggybank para poder quitar la cabecera,
en vez de usar directamente el PigStorage. */
REGISTER /usr/lib/pig/piggybank.jar;
DEFINE StringToInt InvokeForInt('java.lang.Integer.valueOf', 'String');

data =
    load 'forum_node.tsv'
    using org.apache.pig.piggybank.storage.CSVExcelStorage('\t', 'YES_MULTILINE', 'NOCHANGE', 'SKIP_INPUT_HEADER')
    as (pid:chararray, title:chararray, tagnames:chararray,
        author_id:chararray,body:chararray,
        node_type:chararray, parent_id:chararray,
        abs_parent_id:chararray,added_at:chararray,
        score:chararray, state_string:chararray, last_edited_id:chararray,
        last_activity_by_id:chararray, last_activity_at:chararray,
        active_revision_id:chararray, extra:chararray,
        extra_ref_id:chararray, extra_count:chararray, marked:chararray);

/* 2.Limpiamos el fichero quitando los saltos de linea, expresiones html y la expresión regular que se proponia en el ejercicio. */
cleandata = foreach data generate
    REPLACE(pid, '[a-zA-Z]+', '') as post_id,
    LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(body, '\\\\n\\\\r', ''), '\\\\r', ''), '\\\\n', ''), '<*>', ''), '[^a-zA-Z0-9\'\\s]+', ' ')) AS clean_body;

/* 3.Filtramos los datos de post_id que no son numericos. */
cleandata_filtered = filter cleandata by org.apache.pig.piggybank.evaluation.IsNumeric(post_id);

/* 4.Creamos tuplas separando el body por espacios y convirtiendo el post_id en un numerico a través de una función custom, para evitar problemas que sufrimos con el cast de String a Integer. */
words_data = FOREACH cleandata_filtered GENERATE StringToInt(post_id) as post_id_int:int, FLATTEN(TOKENIZE(clean_body)) as word;
words_data_filtered = filter words_data by SIZE(word) > 0;

/* 5.Agrupamos por palabra */
word_groups = GROUP words_data_filtered BY word;

/* 6.Por cada grupo de palabras, hacemos un distinct para los post_id, eliminando los duplicados, contamos el número de post en que aparece (despues de quitar los duplicados) y generamos una fila con el índice. */
index = FOREACH word_groups {
    pairs = DISTINCT $1.$0;
    cnt = COUNT(pairs);
    GENERATE $0 as word, pairs as index_bag, cnt as count;
};

/* 7.Como se pide que el indice lleve el post_id ordenador, ordenamos la bag resultante de los posts por su id. */
sorted_index = foreach index {
    sorted_bag = order index_bag by $0;
    generate word, sorted_bag, count;
}

/* 8. Lo guardamos en un fichero. */
STORE sorted_index INTO 'inverted_index';


