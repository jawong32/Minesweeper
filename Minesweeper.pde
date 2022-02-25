import de.bezier.guido.*;
private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 20;

private MSButton[][] buttons = new MSButton[NUM_ROWS][NUM_COLS]; 
private ArrayList <MSButton> mines = new ArrayList<MSButton>();

void setup () {
  size(400, 400);
  textAlign(CENTER, CENTER);

  Interactive.make(this);

  for (int i = 0; i < NUM_ROWS; i++)
    for (int j = 0; j < NUM_COLS; j++)
      buttons[i][j] = new MSButton(i, j);

  for (int i = 0; i < NUM_ROWS * NUM_COLS / 5; i++)
    setMines();
}

public void setMines() {
  int row = (int) (Math.random() * NUM_ROWS);
  int col = (int) (Math.random() * NUM_COLS);
  if (!mines.contains(buttons[row][col]))
    mines.add(buttons[row][col]);
}

public void draw () {
  background(0);
  if (isWon() == true)
    displayWinningMessage();
}

public boolean isWon() {
  for (int i = 0; i < NUM_ROWS; i++)
    for (int j = 0; j < NUM_COLS; j++) {
      MSButton button = buttons[i][j];
      boolean notFlagged = button.isClicked() && !button.isFlagged();
      boolean flaggedMine = button.isFlagged() && mines.contains(button);
      if (!notFlagged && !flaggedMine)
        return false;
    }
  return true;
}

public void displayLosingMessage() {
}

public void displayWinningMessage() {
  buttons[2][1].setLabel("W");
  buttons[2][2].setLabel("I");
  buttons[2][3].setLabel("N");
}

public boolean isValid(int r, int c) {
  return 0 <= r && r < NUM_ROWS && 0 <= c && c < NUM_COLS;
}

public int countMines(int row, int col) {
  int numMines = 0;
  for (int i = row - 1; i < row + 2; i++)
    for (int j = col - 1; j < col + 2; j++)
      if (isValid(i, j) && mines.contains(buttons[i][j]))
        numMines++;
  return numMines;
}

public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton ( int row, int col ) {
    width = 400 / NUM_COLS;
    height = 400 / NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol * width;
    y = myRow * height;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add(this);
  }

  // called by manager
  public void mousePressed() {
    if (clicked && !flagged) return;
    clicked = true;
    if (mouseButton == RIGHT) {
      flagged = !flagged;
      if (!flagged)
        clicked = false;
    } else if (flagged) 
      return;
    else if (mines.contains(this))
      displayLosingMessage();
    else if (countMines(myRow, myCol) > 0) 
      myLabel = Integer.toString(countMines(myRow, myCol));
    else
      for (int i = myRow - 1; i < myRow + 2; i++)
        for (int j = myCol - 1; j < myCol + 2; j++)
          if (isValid(i, j))
            buttons[i][j].mousePressed();
  }

  public void draw() {    
    if (flagged)
      fill(0);
    else if (clicked && mines.contains(this)) 
      fill(255, 0, 0);
    else if (clicked)
      fill(200);
    else 
    fill(100);

    rect(x, y, width, height);
    fill(0);
    text(myLabel, x + width / 2, y + height / 2);
  }

  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }

  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }

  public boolean isFlagged() {
    return flagged;
  }

  public boolean isClicked() {
    return clicked;
  }
}
