export interface Whisper {
  id: number;
  whisperer_id: number;
  primary_wall_id: number;
  whisper_content: string;
  whispered_at: Date;
  up_karma: number;
  down_karma: number;
  in_reference: number | null;
  view_count: number | null;
  total_up_karma: number;
  total_down_karma: number;
  total_karma: number;
}

export interface WhisperResponse {
  has_next: boolean;
  whispers: Whisper[];
}
