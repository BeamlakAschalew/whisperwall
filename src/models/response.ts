import statusDoc from "../docs/status_docs.json";

interface StatusDocs {
  [key: string]: string;
}

const statusDocs: StatusDocs = statusDoc;

class Status {
  code: string;
  description: string;
  constructor(code: string) {
    this.code = code;
    this.description = statusDocs[code];
  }
}

class ResponseInstance {
  status: Status;
  message: string;
  constructor(status: Status, message: string) {
    this.status = status;
    this.message = message;
  }
}

export { Status, ResponseInstance };
