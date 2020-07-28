# Progetto Reti Logiche Polimi a.a. 2020

Il progetto consiste nel descrivere in VHDL un componente hardware in grado di codificare secondo la codifica "Working Zone" (da ora semplicemente WZ) un indirizzo da 7 bit.
Le WZ in questo progetto sono formate da un indirizzo base e i 3 indirizzi successivi ad esso.

# Descrizione

La macchina si interfaccia con una memoria formata da 8 indirizzi contenenti gli indirizzi base delle WZ, uno contenente l'indirizzo da codificare e uno dove verrà scritto l'indirizzo codificato dal componente. Se tale indirizzo non appartiene a nessuna delle 8 WZ verrà ricritto così com'è con un bit 0 aggiuntivo che indica la sua non appartenenza, se invece esso appartiene a una delle WZ allora verrà codificato nel seguente modo: il bit aggiuntivo sarà 1 per indicare l'appartenenza a una delle WZ, 3 bit per indicare l'indirizzo di memoria in cui è salvata la WZ e 4 bit (in one hot) che rappresentano l'offset rispetto all'indirizzo base della WZ.

# Implemetazione

La macchina legge l'indirizzo da codificare la lo confronta con tutte le WZ salvate in memoria e verifica l'appartenenza, dopodiché provvede a codificare secondo la descrizione del progetto.
