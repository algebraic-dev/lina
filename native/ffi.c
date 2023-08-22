#include <lean/lean.h>
#include <stdio.h>
#include <strings.h>

#include "./picohttpparser/picohttpparser.c"

typedef struct {
  char buffer[4096];
  const char *method;
  size_t method_len;
  const char *path;
  size_t path_len;
  int minor_version;
  int major_version;
  struct phr_header headers[50];
  size_t header_count;
} lean_http_object;

static lean_external_class *g_http_object_external_class = NULL;

// Constructors

lean_object *some(lean_object *v) {
  lean_object *option = lean_alloc_ctor(1, 1, 0);
  lean_ctor_set(option, 0, v);
  return option;
}

lean_object *none() {
  return lean_alloc_ctor(0, 0, 0);
}

// Boxing and unboxing

lean_object *box(lean_http_object *s) {
  return lean_alloc_external(g_http_object_external_class, s);
}

lean_http_object *unbox(lean_object *s) { return (lean_http_object *)(lean_get_external_data(s)); }

// Http Object things

inline static void http_object_finalize(void *http_object_ptr) {
  free((lean_http_object *)http_object_ptr);
}

inline static void noop_foreach(void *mod, b_lean_obj_arg fn) {}

lean_obj_res lean_parser_initialize() {
  g_http_object_external_class = lean_register_external_class(http_object_finalize, noop_foreach);
  return lean_io_result_mk_ok(lean_box(0));
}

// Functions

lean_obj_res lean_parse_http(b_lean_obj_arg str) {
  const char *text = lean_string_cstr(str);

  lean_http_object *http_object = malloc(sizeof(lean_http_object));

  http_object->header_count = 50;

  strcpy(http_object->buffer, text);

  uint32_t used = phr_parse_request(
      http_object->buffer,
      strlen(http_object->buffer),
      &http_object->method,
      &http_object->method_len,
      &http_object->path,
      &http_object->path_len,
      &http_object->major_version,
      &http_object->minor_version,
      http_object->headers,
      &http_object->header_count,
      0);

  lean_object *o = lean_alloc_ctor(0, 2, 0);
  lean_ctor_set(o, 0, box(http_object));
  lean_ctor_set(o, 1, lean_box(used));

  return lean_io_result_mk_ok(o);
}

lean_obj_res lean_http_request_method(b_lean_obj_arg http_object) {
  lean_http_object *o = unbox(http_object);

  char *str = malloc(o->method_len + 1);
  memcpy(str, o->method, o->method_len);
  str[o->method_len] = '\0';

  lean_obj_res res = lean_mk_string(str);
  free(str);

  return res;
}

lean_obj_res lean_http_object_path(b_lean_obj_arg http_object) {
  lean_http_object *o = unbox(http_object);

  char *str = malloc(o->path_len + 1);
  memcpy(str, o->path, o->path_len);
  str[o->path_len] = '\0';

  lean_obj_res res = lean_mk_string(str);
  free(str);

  return res;
}

size_t lean_minor_version(b_lean_obj_arg http_object) {
  lean_http_object *o = unbox(http_object);

  return o->minor_version;
}

size_t lean_major_version(b_lean_obj_arg http_object) {
  lean_http_object *o = unbox(http_object);

  return o->major_version;
}

size_t lean_header_count(b_lean_obj_arg http_object) {
  lean_http_object *o = unbox(http_object);

  return o->header_count;
}

lean_obj_res lean_header_name(b_lean_obj_arg http_object, uint32_t i) {
  lean_http_object *o = unbox(http_object);

  char *str = malloc(o->headers[i].name_len + 1);
  memcpy(str, o->headers[i].name, o->headers[i].name_len);
  str[o->headers[i].name_len] = '\0';

  lean_obj_res res = lean_mk_string(str);
  free(str);

  return res;
}

lean_obj_res lean_header_value(b_lean_obj_arg http_object, uint32_t i) {
  lean_http_object *o = unbox(http_object);

  char *str = malloc(o->headers[i].value_len + 1);
  memcpy(str, o->headers[i].value, o->headers[i].value_len);
  str[o->headers[i].value_len] = '\0';

  lean_obj_res res = lean_mk_string(str);
  free(str);

  return res;
}