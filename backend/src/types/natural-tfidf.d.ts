declare module 'natural/lib/natural/tfidf/tfidf' {
  class TfIdf {
    constructor(deserialized?: { documents: unknown[] });
    addDocument(document: string | string[] | Record<string, number>, key?: string, restoreCache?: boolean): void;
    tfidfs(
      terms: string | string[],
      callback?: (index: number, measure: number, key?: string) => void,
    ): number[];
  }

  export = TfIdf;
}
