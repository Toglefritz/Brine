# Battery Voltage Monitoring

A voltage divider circuit allows the ESP32 to monitor the voltage of the AA batteries that power brine via an analog input pin (A0/D0 in this case). An important consideration for the circuit is ensuring that the maximum voltage from the batteries when fully charged does not exceed the maximum input voltage of the GPIO pin. For the ESP32, the maximum input voltage for an analog pin is typically 3.3V. Since three AA batteries can provide a voltage slightly above 4.5V when fully charged (and even higher if they're new alkaline batteries, up to about 1.6V each or 4.8V total), the voltage divider needs to step down the voltage to a safe level for the ESP32 to read.

## Voltage Divider Basics

A voltage divider is a simple circuit made from two resistors in series across a voltage source. The output voltage is taken from the junction of the two resistors. The formula to calculate the output voltage ($V_{out}$) is given by the equation:

$V_{out} = V_{in} \times \frac{R_2}{R_1 + R_2}$

where:
- $V_{in}$ is the input voltage (the voltage of the batteries),
- $R_1$ is the resistance of the first resistor,
- $R_2$ is the resistance of the second resistor connected to ground.

## Designing the Voltage Divider

To ensure the voltage does not exceed 3.3V when the batteries are fully charged (assuming a max of 4.8V to provide some margin), appropriate values for $R_1$ and $R_2$ can be chosen using the formula above.

First, let's choose $R_2$ to be 10kΩ (a common value for such tasks) and solve for $R_1$ to achieve a maximum $V_{out}$ of 3.3V when $V_{in}$ is 4.8V.

Rearranging the formula to solve for $R_1$ we get:

$R_1 = R_2 \times (\frac{V_{in}}{V_{out}} - 1)$

Plugging in the values:

- $V_{in}$ = 4.8V (max battery voltage)
- $V_{out}$ = 3.3V (max GPIO pin voltage)
- $R_2$ = 10kΩ,

we can calculate $R_1$.

```
# Constants
V_in = 4.8  # Maximum input voltage from the batteries
V_out = 3.3  # Desired output voltage to the GPIO pin
R2 = 10_000  # Resistance of R2 in ohms (Ω)

# Calculating R1
R1 = R2 * ((V_in / V_out) - 1)
R1 = 4545.454545454546

```

The calculated value for $R_1$ is approximately 4545.45Ω. Since resistors come in standard values, you would typically round this to the nearest standard resistor value. The closest standard values are 4.7kΩ or 4.3kΩ. Choosing 4.7kΩ for $R_1$
would be safer as it ensures the maximum voltage seen by the GPIO pin does not exceed 3.3V, even if the batteries are slightly above 4.8V when fully charged.

## Final Design

- $R_1$ = 4.7kΩ
- $R_2$ = 10kΩ

This configuration will step down the voltage from the batteries to a safe level for the ESP32 to monitor via its A0/D0 pin.