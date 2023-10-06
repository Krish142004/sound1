module audio_player (
  input wire clk,
  input wire rst,
  output wire button,
  output wire speaker
);

  // Define your audio storage signals (e.g., a memory)
  reg [15:0] audio_memory [0:4095]; // 16-bit audio data, 4096 samples

  // Define control signals
  reg play_audio;
  reg [11:0] audio_address;
  wire audio_ready;

  // Instantiate XC3748 Audio Playback Module
  xc3748_audio_playback audio_playback (
    .clk(clk),
    .rst(rst),
    .play(play_audio),
    .address(audio_address),
    .data(audio_memory[audio_address]),
    .ready(audio_ready)
  );

  // Clock generation (adjust frequency as needed)
  reg [15:0] counter;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
      button <= 0;
    end else begin
      if (counter == 32767) begin
        counter <= 0;
        button <= 1; // Simulate a button press every 32768 clock cycles (adjust for desired beep frequency)
      end else begin
        counter <= counter + 1;
        button <= 0;
      end
    end
  end

  // Control logic for audio playback
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      play_audio <= 0;
      audio_address <= 0;
    end else if (button) begin
      if (!play_audio && audio_ready) begin
        play_audio <= 1;
        audio_address <= 0;
      end else if (play_audio && audio_ready) begin
        if (audio_address < 4095) begin
          audio_address <= audio_address + 1;
        end else begin
          play_audio <= 0; // Stop playback when the end is reached
        end
      end
    end
  end

  // Generate a simple beep tone in audio memory
  initial begin
    for (audio_address = 0; audio_address < 4096; audio_address = audio_address + 1) begin
      if (audio_address < 2048)
        audio_memory[audio_address] = 32767; // Positive half of the sine wave
      else
        audio_memory[audio_address] = -32767; // Negative half of the sine wave
    end
  end

endmodule
