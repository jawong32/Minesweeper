import de.bezier.guido.*;

private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 20;

private MSButton[][] buttons = new MSButton[NUM_ROWS][NUM_COLS]; 
private ArrayList <MSButton> mines = new ArrayList<MSButton>();
private boolean firstClick = true;

void setup () {
  size(800, 800);
  textAlign(CENTER, CENTER);

  Interactive.make(this);

  for (int i = 0; i < NUM_ROWS; i++)
    for (int j = 0; j < NUM_COLS; j++)
      buttons[i][j] = new MSButton(i, j);
  setMines();
}

public void setMines() {
  for (int i = 0; i < NUM_ROWS * NUM_COLS / 5; i++) {
    int row, col;
    do {
      row = (int) (Math.random() * NUM_ROWS);
      col = (int) (Math.random() * NUM_COLS);
    } while (mines.contains(buttons[row][col]));
    mines.add(buttons[row][col]);
  }
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
  private boolean clicked, flagged, hovered;
  private String myLabel;

  public MSButton ( int row, int col ) {
    width = 800 / NUM_COLS;
    height = 800 / NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol * width;
    y = myRow * height;
    myLabel = "";
    flagged = clicked = false;
    hovered = false;
    Interactive.add(this);
  }

  public void safeClick() {
    firstClick = false;
    for (int i = myRow - 1; i < myRow + 2; i++)
      for (int j = myCol - 1; j < myCol + 2; j++)
        if (isValid(i, j)) {
          MSButton button = buttons[i][j];
          if (mines.contains(button)) {
            mines.remove(button);
            int row, col;
            boolean okRow, okCol;
            do {
              row = (int) (Math.random() * NUM_ROWS);
              col = (int) (Math.random() * NUM_COLS);
              okRow = myRow - 1 > row || row > myRow + 2;
              okCol = col - 1 > col || col > myCol + 2;
            } while (mines.contains(buttons[row][col]) && okRow && okCol);
            mines.add(buttons[row][col]);
          }
        }
    surroundClick();
  }

  public void surroundClick() {
    for (int i = myRow - 1; i < myRow + 2; i++)
      for (int j = myCol - 1; j < myCol + 2; j++)
        if (isValid(i, j))
          buttons[i][j].mousePressed();
  }

  public void flag() {
    flagged = !flagged;
    if (!flagged)
      clicked = false;
  }

  public void mousePressed() {
    if (clicked && !flagged) return;
    clicked = true;

    if (mouseButton == RIGHT) {
      flag();
    } else if (flagged) 
      return;
    else if (firstClick) {
      safeClick();
    } else if (mines.contains(this)) {
      if (firstClick) {
        mines.remove(this);
        int i = 0;
        while (firstClick) {
          for (int j = 0; j < NUM_COLS; j++)
            if (!mines.contains(buttons[i][j])) {
              mines.add(buttons[i][j]);
              firstClick = false;
              clicked = false;
              mousePressed();
              break;
            }
          i++;
        }
      } else {
        displayLosingMessage();
      }
    } else if (countMines(myRow, myCol) > 0) 
      myLabel = Integer.toString(countMines(myRow, myCol));
    else
      surroundClick();
  }

  public void draw() {    
    if (flagged)
      fill(0);
    else if (clicked && mines.contains(this)) 
      fill(255, 0, 0);
    else if (clicked)
      fill(200);
    else if (hovered)
      fill(50);
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
