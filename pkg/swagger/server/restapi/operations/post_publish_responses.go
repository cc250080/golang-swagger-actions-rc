// Code generated by go-swagger; DO NOT EDIT.

package operations

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"

	"github.com/go-openapi/runtime"
)

// PostPublishOKCode is the HTTP code returned for type PostPublishOK
const PostPublishOKCode int = 200

/*PostPublishOK Message is published.

swagger:response postPublishOK
*/
type PostPublishOK struct {

	/*
	  In: Body
	*/
	Payload string `json:"body,omitempty"`
}

// NewPostPublishOK creates PostPublishOK with default headers values
func NewPostPublishOK() *PostPublishOK {

	return &PostPublishOK{}
}

// WithPayload adds the payload to the post publish o k response
func (o *PostPublishOK) WithPayload(payload string) *PostPublishOK {
	o.Payload = payload
	return o
}

// SetPayload sets the payload to the post publish o k response
func (o *PostPublishOK) SetPayload(payload string) {
	o.Payload = payload
}

// WriteResponse to the client
func (o *PostPublishOK) WriteResponse(rw http.ResponseWriter, producer runtime.Producer) {

	rw.WriteHeader(200)
	payload := o.Payload
	if err := producer.Produce(rw, payload); err != nil {
		panic(err) // let the recovery middleware deal with this
	}
}

// PostPublishServiceUnavailableCode is the HTTP code returned for type PostPublishServiceUnavailable
const PostPublishServiceUnavailableCode int = 503

/*PostPublishServiceUnavailable Queue not available

swagger:response postPublishServiceUnavailable
*/
type PostPublishServiceUnavailable struct {

	/*
	  In: Body
	*/
	Payload string `json:"body,omitempty"`
}

// NewPostPublishServiceUnavailable creates PostPublishServiceUnavailable with default headers values
func NewPostPublishServiceUnavailable() *PostPublishServiceUnavailable {

	return &PostPublishServiceUnavailable{}
}

// WithPayload adds the payload to the post publish service unavailable response
func (o *PostPublishServiceUnavailable) WithPayload(payload string) *PostPublishServiceUnavailable {
	o.Payload = payload
	return o
}

// SetPayload sets the payload to the post publish service unavailable response
func (o *PostPublishServiceUnavailable) SetPayload(payload string) {
	o.Payload = payload
}

// WriteResponse to the client
func (o *PostPublishServiceUnavailable) WriteResponse(rw http.ResponseWriter, producer runtime.Producer) {

	rw.WriteHeader(503)
	payload := o.Payload
	if err := producer.Produce(rw, payload); err != nil {
		panic(err) // let the recovery middleware deal with this
	}
}