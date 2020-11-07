# Netlist Parser

A simplified parser for KiCad 5 netlist files.

## Usage

```javascript
parser = require("./np.js");
var netlist = parser(fs.readFileSynce( FILENAME, 'utf8') );
```

### Example: find pin labes of MCU

`node pinLabels.js U7 tsp4-mcu.net`

Prints the label (net) connecting to each pin of designated part `U7` here.  Indirect link are furhter traversed for one more depth.

```javascript
{
  '1': '/LD_PWM2',
  '2': '/LD_PWM1',
  '3': '+3V3',
  '4': '/FET0',
  '5': '/LD1',
  '6': '/LD_PWM3',
  '7': '/LD_CTRL_SEL',
  '8': '/FAN_S1',
  '9': '/FAN_PWM1',
  '10': '/FAN_S2',
  '11': '+3V3',
  '12': '/FAN_PWM2',
  '13': '/FAN_S3',
  '14': '/FAN_PWM3',
  '15': '+3V3',
  '16': '/+1.2V',
  '17': 'NC',
  '18': '/IO_Int-',
  '19': 'NC',
  '20': '+3V3',
  '21': '/+1.2V',
  '22': '/FAN_S4',
  '23': '/FAN_PWM4',
  '24': '/LD2',
  '25': '/LD3',
  '26': '+3V3',
  '27': '/LD4',
  '28': '/FET5',
  '29': '/Current_sense',
  '30': '/AD_AXIS_Y',
  '31': '/AD_AXIS_X',
  '32': '+3V3',
  '33': '+3V3',
  '34': '+3V3',
  '35': '/VREFHIC',
  '36': '/VDDA',
  '37': '/VREFHIA',
  '38': '/TH_670',
  '39': '/TH_810',
  '40': '/Spot_Enc2',
  '41': '/DEL_KEY',
  '42': '/DA_VOL',
  '43': '/DA_AIM_P',
  '44': '/IDA_AIM_P',
  '45': '/TH_532BRF',
  '46': '/AD_LD_P1',
  '47': '/TH_577L',
  '48': '/TH_532L',
  '49': '/TH_577SHG',
  '50': '+3V3',
  '51': '+3V3',
  '52': '+3V3',
  '53': '/VREFHIB',
  '54': '/VDDA',
  '55': '/VREFHID',
  '56': '/AD_LD_P4',
  '57': '/AD_LD_P3',
  '58': '/AD_LD_P2',
  '59': '/TH_577BRF',
  '60': '/TH_532SHG',
  '61': '/+1.2V',
  '62': '+3V3',
  '63': 'NC',
  '64': 'NC',
  '65': 'NC',
  '66': 'NC',
  '67': '/Aiming_Sync',
  '68': '+3V3',
  '69': 'NC',
  '70': '/SPI_CS9',
  '71': '/SPI_CS8',
  '72': '+3V3',
  '73': 'NC',
  '74': 'NC',
  '75': '+3V3',
  '76': '/+1.2V',
  '77': '/MCU_TDI',
  '78': '/MCU_TDO',
  '79': '/MCU_N_TRST',
  '80': '/MCU_TMS',
  '81': '/MCU_TCK',
  '82': '+3V3',
  '83': '/SPI_CS3',
  '84': '/SPI_CS4',
  '85': '/SPI_CS5',
  '86': '/SPI_CS6',
  '87': '/SPI_CS7',
  '88': '+3V3',
  '89': '/LD_PWM4',
  '90': '/BUZZER_ON',
  '91': '+3V3',
  '92': 'R54 | +3V3',
  '93': 'NC',
  '94': '/LIO_d',
  '95': '/LIO_c',
  '96': '/LIO_b',
  '97': '/LIO_a',
  '98': 'NC',
  '99': '+3V3',
  '100': 'NC',
  '101': 'NC',
  '102': 'NC',
  '103': '/SPI_SI',
  '104': '/SPI_SO',
  '105': 'R48 | /SPI_CLK',
  '106': '+3V3',
  '107': '/SPI_CS',
  '108': 'NC',
  '109': 'NC',
  '110': 'NC',
  '111': 'NC',
  '112': 'NC',
  '113': 'NC',
  '114': '+3V3',
  '115': 'NC',
  '116': '+3V3',
  '117': '/+1.2V',
  '118': 'NC',
  '119': 'NC',
  '120': '/VDDOSC',
  '121': 'NC',
  '122': '+3V3',
  '123': 'NC',
  '124': 'NC',
  '125': '/VDDOSC',
  '126': '/+1.2V',
  '127': '+3V3',
  '128': '/RX0',
  '129': '/TX0',
  '130': '/USB0DP',
  '131': '/USB0DM',
  '132': 'NC',
  '133': '/SPI_CS1',
  '134': '/SPI_SI2',
  '135': 'NC',
  '136': '/SPI_CLK2',
  '137': '/+1.2V',
  '138': '+3V3',
  '139': '/SPI_CS2',
  '140': 'NC',
  '141': '/XY2_CLK',
  '142': '/XY2_X',
  '143': '/XY2_Y',
  '144': '/XY2_SYNC',
  '145': 'NC',
  '146': 'NC',
  '147': '+3V3',
  '148': 'NC',
  '149': 'NC',
  '150': 'NC',
  '151': 'NC',
  '152': '+3V3',
  '153': '/+1.2V',
  '154': '/TX1',
  '155': '/RX1',
  '156': 'NC',
  '157': 'NC',
  '158': '/+1.2V',
  '159': '+3V3',
  '160': '/FT_SW_0',
  '161': '/FT_SW_1',
  '162': '/FT_SW_2',
  '163': '/FT_SW_3',
  '164': '/FT_SW_4',
  '165': '/INT_LOCK',
  '166': '/FIB_LOCK1',
  '167': '/FIB_LOCK2',
  '168': '+3V3',
  '169': '/+1.2V',
  '170': 'NC',
  '171': 'NC',
  '172': '/PC_CCIO',
  '173': '/FAN_PWM1',
  '174': '/FAN_PWM2',
  '175': 'NC',
  '176': 'NC'
}
```
