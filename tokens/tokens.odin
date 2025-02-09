package markdownpp_tokens

Token_Kind :: enum u32 {
    Keyword_Begin,
        Import,
        Csv,
        Markdown,
    Keyword_End,

    COUNT,
}

tokens := [Token_Kind.COUNT]string {
    "",
        "#import",
        "#csv",
        "#markdown",
    "",
}
