# Política de seguridad

Este repositorio contiene contratos que pueden custodiar fondos y una dApp que
firma transacciones. Los fallos de seguridad se tratan como prioritarios.

## Versiones soportadas

El proyecto está en fase de prototipo y no hay versiones publicadas. Solo se
mantiene la rama `main`:

| Versión | Soporte |
|---|---|
| `main` (prototipo, Amoy `80002`) | Sí |
| Cualquier despliegue en Polygon mainnet | No autorizado todavía |

## Cómo reportar una vulnerabilidad

**No abras un issue público.** Usa uno de estos canales privados:

1. **GitHub Security Advisories** (recomendado): pestaña *Security* →
   *Report a vulnerability* en este repositorio.
2. Si no tienes acceso, contacta directamente con el mantenedor del repositorio
   por el canal privado habitual.

Incluye, en la medida de lo posible:

- Componente afectado (contratos, web, imágenes Docker, scripts).
- Impacto y escenario de explotación.
- Pasos para reproducirlo o una prueba de concepto.
- Versión, commit (`git rev-parse HEAD`) y entorno (DEV/PRE).

## Qué está en alcance

- `contracts/`: lógica de venta, contabilidad, permisos y flujos de retirada.
- `web/`: exposición de datos, manejo de configuración y cabeceras.
- Imágenes y `compose*.yaml`: configuración de red, puertos y secretos.
- Pipeline de CI: permisos, dependencias y publicación de artefactos.

## Qué queda fuera de alcance

- Vulnerabilidades en dependencias de terceros sin impacto demostrable en este
  proyecto (repórtalas aguas arriba).
- Ingeniería social, phishing o malware fuera del repositorio.
- Ataques de denegación de servicio triviales contra RPC públicos.

## Compromisos del proyecto

- Acuse de recibo en un plazo orientativo de **7 días**.
- No se divulgación pública del detalle hasta que exista corrección o mitigación.
- Crédito al reportero en el aviso, si lo desea.

## Higiene del repositorio

- Ningún secreto, clave privada ni `.env` real se versiona; solo `.env.example`.
- Las imágenes base se fijan por digest y las dependencias por versión exacta.
- Antes de un despliegue en mainnet se exige la checklist de la §7.4 de
  [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) y una revisión de seguridad independiente.
