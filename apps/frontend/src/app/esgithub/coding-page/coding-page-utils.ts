export interface CategorizedFiles {
  imageFiles: string[];
  pdfFiles: string[];
  otherFiles: string[];
}

export class CodingPageUtils {
  static categorizeFiles(filePaths: string[]): CategorizedFiles {
    if (!filePaths) {
      return { otherFiles: [], imageFiles: [], pdfFiles: [] };
    }
    const imageFiles: string[] = [];
    const pdfFiles: string[] = [];
    const otherFiles: string[] = [];

    filePaths.forEach((fileUrl) => {
      if (fileUrl) {
        const parts = fileUrl.split('.');
        const extension = parts.length > 1 ? parts.pop()!.toLowerCase() : '';

        if (['jpg', 'jpeg', 'png', 'gif'].includes(extension)) {
          imageFiles.push(fileUrl);
        } else if (extension === 'pdf') {
          pdfFiles.push(fileUrl);
        } else {
          otherFiles.push(fileUrl);
        }
      }
    });

    return { imageFiles, pdfFiles, otherFiles };
  }
}
