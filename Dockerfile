# https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/30798
FROM public.ecr.aws/aws-observability/aws-otel-collector:latest as aws-otel
FROM otel/opentelemetry-collector-contrib as otel-collector

COPY --from=aws-otel /healthcheck /healthcheck

HEALTHCHECK --interval=5s --timeout=6s --retries=5 CMD ["/healthcheck"]
