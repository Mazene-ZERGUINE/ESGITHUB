import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from '../../../environment/environment';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private readonly _apiUrl: string;

  constructor(private readonly httpClient: HttpClient) {
    this._apiUrl = environment.baseUrl;
  }

  // todo: review the methods of this service //
  count<T>(path: string): Observable<T> {
    return this.httpClient.get<T>(this.getPath(path));
  }

  create<T>(path: string, payload: T): Observable<void> {
    return this.httpClient.post<void>(this.getPath(path), payload);
  }

  delete(path: string, id: number): Observable<void> {
    return this.httpClient.delete<void>(this.getPath(path, id));
  }

  //#region     GET methods
  getAll<T>(path: string): Observable<T> {
    return this.httpClient.get<T>(this.getPath(path));
  }

  getOne<T>(path: string): Observable<T> {
    return this.httpClient.get<T>(this.getPath(path));
  }

  getOneByField<T>(path: string, field: string): Observable<T> {
    return this.httpClient.get<T>(this.getPath(path, field));
  }

  getOneById<T>(path: string, id: number): Observable<T> {
    return this.httpClient.get<T>(this.getPath(path, id));
  }

  //#endregion  GET methods

  //#region     UPDATE methods
  updatePatch<T>(path: string, field: string, payload: T): Observable<void> {
    return this.httpClient.patch<void>(this.getPath(path, field), payload);
  }

  updatePutByField<T>(path: string, field: string, payload: T): Observable<void> {
    return this.httpClient.put<void>(this.getPath(path, field), payload);
  }

  updatePutById<T>(path: string, id: number, payload: T): Observable<void> {
    return this.httpClient.put<void>(this.getPath(path, id), payload);
  }

  upsert<T>(path: string, payload: T): Observable<void> {
    return this.httpClient.post<void>(this.getPath(path), payload);
  }

  postRequest<T, R>(path: string, payload: T): Observable<R> {
    return this.httpClient.post<R>(this.getPath(path), payload);
  }

  getRequest<T>(path: string, params?: HttpParams): Observable<T> {
    return this.httpClient.get<T>(this.getPath(path), { params });
  }

  deleteRequest<T>(path: string): Observable<T> {
    return this.httpClient.delete<T>(this.getPath(path));
  }

  patchRequest<T, P>(path: string, payload: P): Observable<T> {
    return this.httpClient.patch<T>(this.getPath(path), payload);
  }

  putRequest<T, P>(path: string, payload: P): Observable<T> {
    return this.httpClient.put<T>(this.getPath(path), payload);
  }

  downloadFile(path: string): Observable<Blob> {
    return this.httpClient.get(path, {
      responseType: 'blob',
      withCredentials: false,
      headers: {
        Authorization: '',
      },
    });
  }

  //#endregion  UPDATE methods
  private getPath(_path: string, id?: number | string): string {
    const path = `${this._apiUrl}/${_path}`;

    return !id ? path : `${path}/${id}`;
  }
}
