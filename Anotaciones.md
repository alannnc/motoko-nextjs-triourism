### Verificacion de usuarios:

Se deja implementada una funcion para evaluar el estado de verificacion de un usuario **`userIsVerificated()`**  mediante la cual, en un contexto de produccion, se permitirá la publicacion de espacios de alojamiento solo cuando el usuario publicante esté verificado mediante algun tipo de procedimiento KYC.
En un contexto de MVP todos los usuarios serán inicializados por defecto como verificados.

---

1: Solicitud de reserva.
    A: Se evalua si el la fecha de la reserva es mayor al tiempo actual mas el tiempo minimo fijado por el host, o sea si el host dice que se puede reservar con 24 horas  de anticipación y el usuario quiere reserva para dentro de 10 horas, se devuelve un error.
    B: Si todo va bien, el backend devuelve los datos de la solicitud mas un codigo de pago.
    C: Cuando se arma la transacción en el front, el codigo de pago se pone en el campo Memo y se hace la transacción.
2: Tiempo de bloqueo configurable (40 minutos por ejemplo):
    A: Durante este plaso de tiempo se marca como no disponible o pre reservado todo el rango de tiempo correspondiente a la reserva.
    B: El usuario tiene tiempo en este plaso (40 minutos segun ejemplo), de proceder con el pago de confirmación.
    C: Si el plaso finaliza sin que se haya concretado la confirmacion, se vuuelve a marcar como disponible.
2: Confirmación de reserva
    A: Si el usuario realiza la transaccián, la cual devuelve un transaction hash, se llama a otra funcion de backend enviando el id de la reserva mas el transaction hash.
    B: Mediante una consulta al Ledger correspondiente a la moneda de pago, desde el bakend se envia el transaction hash, confirmando que los datos de retorno sean los correspondientes a la transaccion solicitada (Campo memo).
    C: Luego de la confirmacion y verificación se marca como ocupado en el calendario el rango de tiempo de alojamineto
