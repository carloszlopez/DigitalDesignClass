# Quartus project for Cyclone

El sistema de un control de luz de pasillo donde la luz cambia su estado con el cambio en cualquiera de las entradas. (S0)

Un sistema de mayoria de votos, donde la salida es 0 si en las entradas hay mas 0's que 1's, y genera 1 si en las entradas hay mas 1's que 0's. (S1)

https://youtube.com/shorts/maXqp1h_nX0?si=YCNW6qp_jKpfRWFZ

| A	        | B             | C             | S0            |   S1          |
| --------  |   --------    |   --------    |   --------    |   --------    |
| 0	        | 0             | 0             | 0             | 0             |
| 0	        | 0             | 1             | 1             | 0             |
| 0	        | 1             | 0             | 1             | 0             |
| 0	        | 1             | 1             | 0             | 1             |
| 1	        | 0             | 0             | 1             | 0             |
| 1	        | 0             | 1             | 0             | 1             |
| 1	        | 1             | 0             | 0             | 1             |
| 1	        | 1             | 1             | 1             | 1             |
